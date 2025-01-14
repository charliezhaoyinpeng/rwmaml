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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2170595021232qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2170595021712qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2170595023056qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2170595021040q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2170595025168q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2170595022288q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2170595021040qX   2170595021232qX   2170595021712qX   2170595022288qX   2170595023056qX   2170595025168qe.(       �����I >�����>E���w�1��+�=I꽿ɠ��bC?�!=���=i�N���y����?7�L��ǒ��A5��:�?;�d��t�:�l�XP��&�H�ϙr���$��׃�m��>T�`�h���e�IOf?�Y�� ��=/����8a=ge~?�.��B?(       ��0?dH����>� F?D%��k>ܳ�=�h3=�$F?��%=��-�8̏=��=�O�>��<�m:���B����=��Ͼ��B>|�0���D?�(����
>9�9��7L?ؕ��棾�>�z��7K5?zIr��U'?�����y�y��=�W8��<d��=?(       o�*������mW��Hп+����q
=CI�<op�W�Z>��>_�>�Ef>�۲��Ry>���p�¾@\�>���=� �A��>�5��vX�O�>C�ڿg�¿IQM?n���;c��< a2�>�>ҍt��Ӥ>�E��{m>�*�s�(?ůj�m~�       �
��@      *��Z��>R�=��D=ג�<�M^=�Ol�&�#?��=�P�����=�o�����騽��>��!>�!>RU��p>e�=|<>���<����A��?|�ɾ�ܸ��D���,�>��=�lf>`��;�LO>Z��=�M�=ڮ�>Ezֿ[lu����d����Tʽ%�7���<���˿1g��<���i���Y�p*��G����Y�<�ً���l��5����"��(Qj�����V�>�b$�״�=�ה<n9ݽ����W��'�]���?�[�u�&�A�>,47��ƾ<$[������Te�� ��RFS?;��V|�Z?"���N��=a�R���1�#s�;��G�t��=�ڍ��.��z��	�&�r��=!�ֻ\��>�DE��	Ⱦb?�� ��-u�I����+�l	>�����-����C�?�-���:�h�Մ��4q�����ο��v���T>�����l�?������Q�f=U�M�����"@v=T/�+ԃ��������b
���a�70?v���|NS=�=>k���C�,ɒ�d��'���MB]�#S?D�ѽ�[����?��ؿ��3�� �>#Lƾ�� ���1��=�"�?7Ô����>�����=sO=�����l�x�>����<�Fg=����$+�|�'�O{�������;��>�񺽿��>.?=�T.��e>��v>4
���G=�A>�[8��὞�=s�>�@\2��[;>f�?V��<�i��X>������M��=K�=MV�M�'��M�=�ͽ��>�^��)}=S���o�<6�o��b<��=:6���Rb�O^>�u�=܍��3 ���?�����\1�d ���_�B���a�4�ؾ��3�Lp�?�>��3=�ر>v�ҿ"I>0㝿�����>8����2��7Z_=��;Ɍ@�<�<�::��6Q�n:Y�����u>ӗ����=g@d�\q�=���<gw>{��=�o=�{��佪��G6��d=4����=�‽q�P����ȧν�c>�9�5&<h)�<&�c��1f�;��=��
����=��s
*=CX��>��_��q�r�=o�=� >���,��)/^��/{=���>��ҽ�,�=�\6?(7���=��<О��z�<��?S��=q$�< 5/>������e>S�Q>�]]��{(���	�O�?��[�����7�5Lν��s=�A�`�>>����0>��!���?דO��V=^�E?͊P���j����/��V��!���Ne�=pƟ�f<,�wf>p�=��M��������B��ⰽ�P�p��<�7��z9��p9�w��ѷν��2�։	����=��:9?>ݷ8=�A��� �=/��=g�Ժ~-�=��=/6��R,�t`�=�=����a��< s���O����#=v$�Rn<?��>]>�B>���=1��>�X�>;uu��약�!B?�9�>��>��b쾎�F��Wx�7<
���� �>�M���E�[j9? %Ⱥ����l�!��\�f�;=I}����8�U�<^Y�Y|8>�>�T�=��;*��nd�=2��5v��^G�݈����l�!��(���a&5��rN�!a=]�s{>�1�?��C_��ȷ��H=��;�!宽���<{⾘���1���^=�W2��
о9\�P����\?c��9�þ�����3�z���(� �L���?n�<�'�n����?�����>y'�P�G�k����{�|�n 0�E����OԾ�f�/���>����2�����`>�%�����k+>�8���㜾�)��|��OUW��]�R�+1?=-��f����վ�����%�<:��RN�>̫%�0X���,�z�s?���t�P��}�#�m@��D��=GfѼ扃����<vǚ= ��\=�=��/�C� ��E�x���@�k�b�޼˴9�J݌���e���F������@;�Ђ�<S=߽x�K�#�<�-{�p�lU<=�wN� `��T��Յ�g��:�Q�jc�����J��=v��=Gl��m�>`����L#��t�=r<�=�Ͻב��"�Rp���ǽӍ���א�~e��K
�l���P��=��t�|u(��� ��?ݽ��p<��f�	o����f=�P��������^;��S�(@ڽ��;�� "<E�g�mu�ȩ����<��ϽI�=`nb<�>����?4�=�lW=�8a�i^���}����=
ҽ�r?ұ���e�>�?B�@^���� ?��=?��>����/�7?���,����&>�]>4��;��M?j��<6���W�?��!>S_�>��J����=v�2�Io��m��C��xۿ2�I����۔>�T�=4)/�$H�з��\�r�X:�����A`��ۢ=�� ���D?�DA�r��N��?�qP�&	�3u���i�i4h����>�{
=6�=��x�
��g�=�?D�=k�<(��= 6����> Z�9gB�>�.>پ��I���3��à�������I]�+�b>T�V?� ������"S0?#��?۾"?x.	�-�	>��U�I�<��>>���>���>��
>;M�=+�>��j>�ؾ�2��{�
�3>�F=�{9�A� aD>� �>�D�>T룿��������4t[�� <�Y�>E�[����>8>?p_?��$=O���(��� ���mڤ>�n�=�F��{N� �p=����j��=�r������z��=�����=Ϻ���!��v ��|�N��=����1>��?x���E��"�>/	.=�:�Z���X�X�p<�L��*@�̅�=����m���!���b< �"��c����(��䏽K}ٽ�k�<�\��oh�*�ʽ�����
ٽY�-��7������H<
x=?���=��<�mh>�E?C!�A���B����.O������Q5<��<CH�>���>M���9��>R&¾�nk�4�+�/�����O]��Xo�u�e?��B�e2�þ��W�ྔ�O>3��	���ޗ>�"���߄=.p��F
A?���P�?�ৼ&:ؿ��*?4'/�����eq>CYQ?�}�������J���߽�1<?�˸�@�R]d�����t�>�O?iX׿Ҟ�=�����<">Y���G�=�����տ��=;;�>ZH�=�nQ��\&> Z>ˡ=���=�o��ߎ�S }>���>h����>2���i����M=�q��ˑ����H���9��=	���J~>� ��ˡT>ť���>忽��W�������:k>~�;��x>���>�v����Y<��=/<*�
r�<'G�>� ����+>���>�\��y?�,�>tW`�3~F��)��|���ο�����Ǳ=uh�gx�>�<c>Wä���>r�1>��>"X��ʷ����=���+P>�s�>�m�=.��<�4�>j&�:����"���>ݖ�[�	=,�=gk>��?�
�>�^5>j�8BI�b��>/�>�e���)S>���=�14>�'>��?*�>k��>��-����>)yy>YY>�D�Εl>���=F��:	>"ή=�=�>%G�=���>�������>9�> �m=�[����5?��e>��>������bA��l\�|c�=`��>��ܼ�>h~��^���J�>���� �.?9������|�&�P�X>�?N�ƾ~-ؽ�Q�J��>�C(����>�&���6k�G�g>Οѽ�H�=�Y�?������#���ΣY>"�4�Q�=�v	�I����˾9W�<b]*?�1���}y=�X䒽�0��"�����}>k���������>��t=���=��B>G�8���꼅 !�[&>�>S}�C?*���^>���<7/B>\7�<������>=��KF>M1��\B��ڈ������=ꊶ���>�,9���W0�"jb=��?H��={��"}4�հ8>�e��B��a" �U�����GFϽ<�F�sNK��=)� ��;����ǽl3̽��Ͻ���d��"w�=Rt�=�ȡ=�}d����Uy>�����;:i�@�;ܚ=п����9<��=�H
�/̽���=C�=�"ͽ�������&��=��=e=����Lq���۽��~�
�\�������9�Z�e�_f>)o���{�U���:C���>�X����s�=;>6㔾fx���e�>��C>�K�ZG�=B��=rV������J��i��ܼP�����`��&��a�ý؀ =�p�\�c�x�U=XEϼ\ט�>�#k�������,=~�-�ro���vq���󽸟!>K*-���?!/=�+�=Z�r�=a>i�`<��B>�A�=d�
���<Oiӽ୛<��r?�qh��������P6=�ؽ�28>�����i�C1%���l���v>��=n3��M�@�H���r�>�����ƿ�d2�S����-�QL����������I��cʽ�>�-нo�>,9����>7���.�>�d��ƼȾ��'��B�����[�)>\"ҿ�I�K�R?!�s���J���Z��e0���=E^���>���V�=$N�=���?:K�rv��l-߽���=ɉ޽L�0�T���[�*�@iʽ�y ;�!�`����q����=�����<�5\�z^.�����IA��AC�4ký�n��SѽY5��
.=
��$*��� =]'E��>d��������[�l�^=��D��>8�b�4�߽䝀=i������>�(?��>#"������y?J��><ƭ>.���I
->�-��=���H$I?�����>�;�>�� �ܾ�U�=NɁ�q�5=�6>�����Š=(@>qb�>9��>��=�_������o�����=�e?�ͱS���辋Ƃ�8�?�粽�'��M�=�ڼ�����%;�)4�H$������&=�ȗ�l�����<-:��I-�=v��=���=�b}��|<5��O =�!=p�J<fր=K�<�������i�����<Nl=k,��n��o�=��������;�=�ͽ��߽c��=E�0��0=5ٸ����������ti*=��q�d��<�!_=� ��G�>����:�"��=�̿uc�=��ս����8�6�>�"R�> Ds���(���Hɳ�7G>uE?�Z+��D��ʽ�X���M��Cʽ�_>��>�c�1���.?�_�������Lѽ׫>�4=���=xk�>r`=�o>��<½�H�7�&S ?cB6>>z��	���O�5�->h�$�+�ؾa�4�V���-W$?k�
=j�����>��?S�=�����q���>�඾q���>��>��?1 !�?����?��}��*>'y�>�P��W�<��?!������k>\��?%bR?��u�^EZ�V�H��r��_�>�;w�KX'�?�>+l#>�۾C��?�a<�u��s�����T'=t�9[��� >c-�><��>��F?���?>�O=�3�vO㾴�>�⿮k�=7Ci>����Փ��>>&�ǽ�/��M�>�!��裿�<�F>:�h>�IF�,u6�k̾|��"J���}��'�=��+`p=8>>(�`�3�z��=�{;����<��Խ3�s��:�=�v��d�<z�=�á�Do�=�3 �⚽��v��񽑑;� <`��1u�nc+�R�Ǿ]Œ<��+��\�8喽'[н���x���j��<�Q��;)�뒇��)C>c�>�����fҾ�¦=b.,���#=-7K��=K�B��=ka+�+ržpc%=G2?��T�SE<7t˾�ۢ���ѿ{ �>�wC����=jp�$`���Z?���<wH=V��=����s�=��¶��
�!����?Ŭ�>��h��q�>�Q?yE�>2�%���=�vr��3y��i�!�{.����>��N�?��o����պ�?Ϧ��) ����&�=����w|?��̾1'?�I��KR�>h?>7�!>t����V��D����n�=H$�<���[���0�>�jR+�,��=kb�<m�=V��<��x�RS0�	\3�p͙��}���;�=��3W	>h$���	�<��p}����������-�7>2�&�P�K������cؽ��>CU@�������=H�T=Ŏj���ļ�6>��=`���.�A��$o�V��=ۧ���ަ�'�4>}�_��@2�����Q�=?"�J����>�b�=�?�K�e?��~��@���r�>���-sQ��m����� ����>�%�p��a9�b�J�AԼ>i�[��k��1
P�~V���
�ý��k/>l�ݼ����Y&>lE�>(       ��>�Ã?nȅ?̇@�h>gl�>"�нN.�>��#�M�e�z�?���>���;^=�?���u�>�㧼�����ھ dK>nĨ��!?�Ϲ>��[>I�<L��}3>	Y'?�CӼ,���*x�<I��z>�iF?�����B���G�n���+�