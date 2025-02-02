��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2327165747520qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327165744352qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327165747904qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327165745120q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327165745024q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327165746560q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327165744352qX   2327165745024qX   2327165745120qX   2327165746560qX   2327165747520qX   2327165747904qe.(       ��@���,!=�A)\>,��>�>q>CE�s|�Q�=�3ԿJ2�>F�,���`�8[��hj��J ?��Av�>]�?1��=��A?c�;=2F5�B�>
5=h��>�fm>��Z�[)�>]�������#�+��P�L-���#������ �>/&"�jĬ>�E8�(       N�<o�E?��7��a6<{��`��=�I'=�s�E�?{ܫ=~��>΂>?��?]� ���^�����(�6�����6���>a�9��:W���'?E?Ld:���V?|F?�!d?c{!�s�.?\� ?��>��?־o8�?4��<����I=�(���&>�'�(       �B��k��/_��=��*�&?w�=�d�g�3��O�>+x��؛����{�ù�<���V�}>I3="�=
К=��(��1��ɶ8?2��<[2��vE��T�>+�>��/�`���$�X}�m4���r�?�?C?$���'мQ�?'�W�	ݽ��O���s�       ��a�(       �߾� ?@�`�-�=(�X�����_:?Y�&�F��=Ɉ��#L> ���E}>����>�M�`E���=�����@�ޫ_�lY�.w�>�`����}=@v�X&����?s�����>'l9��'ܾ�E?0�?7�?��8?��=Ym� y�=��+�@      ������ �а�"
�8�=X5�;��k=MĻ}�?�a�F�<��=]���f�=EY�	<y��Q:�#Q�^>뽾������� �S����<�ɔ�����M�<�l=��b= ���@<���55�=^+N���,���6�@�{:{��������=��8�@qy�EA>��U�
�>����?u���B�<M��<�*�(T�>2~�m[>�:�=����?�D���P;{��1�������U.?.,7�?B�	���H?���>���=�.��d����n�q}��q�����V�:�k��M�>���	Wf>.f��3|�К�=a�˼?½__=�Q`�Cy>dw��|��*w�0v@=����K=�JS=c��w�Ƚ� ��|�=���<�k�<�3B��Qݽ,w=5�A�ܷl��"O��M��`Mn�C��(�ν���M���6Q�����1>�����_=<�:��Ý=�b��0==Jv����h�<�@V������&=�#�<�7�<mK>J9�����=�>��=�V=� ���=6ꏽ8��M%=����,�=�o=lt�j�=(�&��L��=P�1�ձ=f�=h����,=j1��������a�^�:��������v =��s��弿�ǐ=�Y�>�R�=���>Q1�>?Ls�S��W�V�,�=�ߒ>�]��,«>��? p��5o�=w� ��:>�?��H���B>�.&��4>uP�?���=�p��ï^>A�:>����s�>B�?��=��>?�;=��z=����a9ӻ#:*>Uݽ�Ē�k*ͽ��)Ƚ �^�C�Z=x�.�^&7�_�>��=�C�=Ԉ<<� �=a�-<��W��F��t�:��e���ͽҒG��+>
Q+��m�4ǽ�'�<s�<���#�=D˸�5]>Rk�4m=���;~[x�'}%��s%�^M�=�lȽp�l<!r��faٽ`�u����O��;.?���j��4��:T����,�J-�`��;+��U������T5>���������G=�o
�6

>l\��ܾ=��>���GW�"/�9����c�=/�N������%�=�w���5>���HDt��H;�۬���
���c˽��6��EL=[��^�pJf=L������׽與�g�=�ٹ���8*Y=���=Y��X��< ǽ��S=����,�=�O�ĳR="R�@"�f7�+���%!=�|b�D��=�,��$gp=>�=�8��Ȉ�=�VD�����x>�ȅ��녻�s?]�?�a����f>lr0�-D?� ����Q�K>^���O�>%�>�=�A�}����?�0ɾ7���?����E�v�W���_��38�?�io�����Aׂ��D꽅.ο&��=2�vȿ��?/6`= H�Uw澊�>mz��&�!>��>Uh���1����=�2�Y��=U����Nj�_K>1jj���=l���ɯ��������q�;�3>G��퓾���h[�������ý��Ž�����F=�2��}g��N���;���� ݽl��= �<��ļ�༆�۽]凾�=����Q�$�&ʹ)Ya?-�
�W�(>~)����F-�>_=�����>Q3=���qU�j?߬?<-�?�O�?e*�?ŧ��}+�;ɾA�[����;}��0���� C?v��M���/�>����>荰>X�l=�g��#@�ИY��2�lt?m���=�n �;Y�� ߄�C�=�C%��@�?=���^�>-��"]>@x�ܐݼ�H��^˓<�����|��0e����k ?��<�U?��=�X@��>N��=��?f9�ڜ���v����P˾)�>m@P=b�>�-��Y>�侁�9=�	���>����Q"꿼������?�b���+	�VC�'ؼ��=N��	U�����c��5?}���l�2�"�@�k�=�%�<UvG?�������?/�6��PA��P<����G��߾��5��yѽ��Q�[����f����ڤ���⓿������ɻ���=��4<ޢ���C<����J��\N�Vj��a�G̽`,����ɽ�˽��=#�輽���������=Ϳp����R�����m�����|������=x�+=A��=���=��:��;�@� ��=H��ꎬ�?'�z����q<�R
� h���>.>�+;�4�k�d�?��>���?�R�d"p�����EϽ~�(>�K
���=�"+?M���[��%?�)�>9?8�O��B>�k�>�R����>�Z>�y�<��>F��=3p���,I?�M޽�1�=�G��o�7F���������l{E?�v"�$����w>22(>wd�=F�)��D���K�ؾ��5<��7;{��`n�v���(>��B��=���>-p?��i?0�O�FWr>yT-��g��D�{��Q������~5�^	|��>j��4��=���;�;o��y޾	�+�w�-�#l�<6�)>g�ȼ�ѡ�S.��D�
<��6�]��G����p½�m&;�<�[=�w�=	f�
>z��ց�=��½��]��%��>��=�7�N'������{{��3F����6g���;�N0�gJ���4Q=oR�<;tݻP�ξ�Q<���=]�G���r=|]�����xۼ�����;�r9��!��i��L� ?�C�!�-�u�C��s;�`!�]�>�	q��a�/G	=�I?UE��W��>?���ӿA���v����=��?�>�?�a����=��=L���n**>�Ɲ��؍��忢�>Nľ�$o>g���yK�D�Ľ�������V���k�>�6=�+��!��=E��<���<V���G)>�,ѽ5+���=-DQ�N��<�#>�Z8=�<���ѿ���%�J�P=�oL�l��Cy.��_>H���K�o�+��`-���>�<�=��>m�=����,�&��(�����>��=��>��Ӻ=��]��|�%ڴ?����� (?� ������2��o����=5��=	�����>�Ʒ��w��4e��r~I���[�a��Z�?�t�=�����?2���Kx*����=��?�\�=2y�����;���U>J/:?���>젥<����w�i�A㴾���>g��Z
B�����?�����~�D�d���3�����WwG�e���ř����߽��4��N��Gfǿ�׳>zK��v(>ibź�i6?�?žR������?B�4>59k>���e'�?��������k�E�j��S꾥��^�:��q>!���3&>0�;�(h=��Ա�t
���0�t܇���=n�=�n��^w� ��F�;�۲��n��=L�̽���<�?><ތ����]�==!��m�<�rJ=�����<l����	��u�Y���G,�=�� K�:�5��vі<(�>���ў��5@
>�3���	��c��J������>�d:�h�g<*؋>s�S��U�=�Jþ��A>[循}�=ɗs�Bd]?µA�L�>�1?�Ƌ?���>�B�ٝ��?����=a�Q�
|��r?{�3�������n�[L�>��*>j踽k���<A��R��6���#R�=)>\�<���?H2�"��``�����=�@>��j��>��)跾�{��]T>sl"��������x�T�t�׽1�z�7�]�U>�8�h��?V�:�돾��?ܗ3�b�>����M;q?2�E��Ab=/c�>������|���T=��Y�� ��]������%?U|�>C�7�����G������?혚>)� >M���nw����T�;.��c���j�r>���>�#��Ԭ���>9�x>>@	�p��<A�Q���@q��>n��=]��>�W潎ݿ�f*�$��C�>%a��_�$> �/>�O��j�����=&���T�>�W׽�@5�jԿ�n��$���a?��2���'�yV>�̓��V>~>v�P�S����]��?y�M�CEܾ�ʮ?�/!��c�>	���&Ҿ��?Ew����9����f=��ᓿ}}
�I��Rذ��>�D]����h&���(�{"<�tћ=����}�
�%=��~�,�<�9)����?���c᡾��� ��������+��H���!��nPѽB;����R=�A�=e7�q��h?4�fPƽg�����@L#?#�4>��4�]�#=�n�>�ʜ�)	�\�پ�����=���1�>�˞��j��RL��������R�N�>E��c��P_`��(��O�>�����}=�/>F@,��>Q)���ײ>������h��>s�)��y� 8g�P��>��>���c�?'>)T��A�>�x@>is�>���R���U]���~>��q=���>xҢ<���'[>�B���c�M����9�<�x꽂MG=e����?=d=@zz=S}#��ٽ������a��=��o<ϐ=�C<�J=��;���<+-��H޽��p<2�>��m���#�(� ���x���N:�M��=9�O=�-�mK���
��� �=Xx�<�WV��qQ��"-���{�{�=���[U'��)�?�`��b�>�\ھ>�Ž�냾KB?����-��l7���Ȇ=ZV�dx
��P�>x"�>��\���i�%����ԙ=�B=�/�ֿ ks�܄����=ގ;@hh>�}6��d����>�4�=S��>},@>!/!����J�v����r��=0���_)>�־�>��}�0��zҽ���}�¾��I�H�>��lž@5u�����Qu����>>b�@.����`;I5���K$><5�d�ۿg�>
c�>͆Ͻ�E���7? 6⾾ޡ>����Eֽ��e�a�2��&x�5�M�n �>��3��5�=3���(U=vN��n>?Ze��B��q�:ڧ>I>��z��>@"x<�U�=L1H�-rt�ͿS�6t�>����6�'���ɽ~��J�н�R?��E�d����\>4z?t
>}����~޿��L��S��2�#J�>�Lf����>���#�>��=�6�>N�=~����O��-!�(Wb���>�w?��$=0�i��BX>)\?�H���C��	��=�^ɽ��Y?蒿��U���!?&{��v>T_>U��Q����==y*�?��>�8����O������5�6�߾;��:��:>D{�=_�ɿ���O�����=4L@������>�(���5��V��"��=4 ���4��U�=���nϨ�O��<�!?	#ܽl���̻��.��c�]?ø����z�S�<��� �)@��:����&`ƿ{3�>"B]��v�>+�%>�7�=�����=#�O����v�x�q�r����=�0a�A���z��㽆t�as��(R����Ԅ�h
��QN��h��s�^���J=�����\�ɕ��Z��.����<T�wz��Y՜=Ij����x�M����g2�[���$�kG�z����<p�#��w�==ʞ��i���j��HE��J�>�,��+Ľ=8��\����s�ew���ǽ2�=����lI�;B���� >H���b���0L��?k���H��#пwt�>��Y?ж�Xw���@��ʆ>�g\>	%�>��R��hὈ�-�£�>e?ξ8�[>t*�����Ͻ=7{K���)=6�Ƚ݂ >�A=�������_]=��N=8�F<�/l=�;���!)*��`���.�{+�%R�=pK���2�<S y�i����J�=�����=�5;��;����=���=0.�=Ni�wz>�$�T:Va��r��=*V3=	��=�,�=�Z��!>l-%�39�����I5��Q=n��=H� ���#�=�k�=�j�=���<�	n���~��<�<B�B]m��(���3w��K2=ց�ߌŽY`1�o|���إ�n���%=��@�"L��CP,�bLT�H$f=Ǖ�=p;0 0��$x<\CB��̘�V���0�<�/����=�����=�3A�Rl��#��=ي�<��l��2�9^��9�=��� *�:2�<_���s�: XH�!���j������)cP=�a=
�^���j¼�7D�8�ۼ3_�!�����=#k1<��
�E�'>wE���⻩r㽩�4�X�K�S��;׼<�� 3�n~����9+�=�D�H��=�>����q��uҿx���U)�t;������ސ?y�߽���:G�?Q����f >�}"�.m�=��R��w�pɏ�n�����<!�ž�K��$�>�52>�l=��=�(K=@��4ſ�3��N����,>