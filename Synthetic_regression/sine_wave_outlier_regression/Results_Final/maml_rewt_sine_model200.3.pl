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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2327161729456qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327161731184qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327161732432qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327161728880q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327161727344q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327161727248q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327161727248qX   2327161727344qX   2327161728880qX   2327161729456qX   2327161731184qX   2327161732432qe.       ;��(       �dr?�T���U�?�r�<���>6���
>�J�>g8���z.��V��?h�����>g��>��> >L3|?g+7��Њ���>a�?�?�'�=�$=�>b�2<��?Y�2�8>��-��]	>3�o?ϐ>(/?���9>�E��6C>�	�>pR�>(       i�f>�����%=�Q�H��:cD��8뀽{�,�� �=�p�>o#	>��C?�n�?&)�����Ҿ�h'�j�>> a	� Z�p�W>�bJ>v�� >'���;��51�>ɻ�>�Mh��&?�r�=�;!�-��9M=�~>�d���	�>P����=ao�(       ��5�.�?u���Ǐ��|����>y,??]|��k9�qZ?I_Q�0�/�]o�@����쉿񴙽�?8�j�s`�:� >���=��$�M6?`D�:ӳ~>�K?x�}����=������;p��=b�>al	>hCx��^Q>>�����e>eO1?�-a>(       �_+?���f�V>��/�摃���׾�.��N�?��1�G,ǿ�$��f���@�>�
r�9���i�>�1ſ\����.>���>��>O-�����r+��wZ̾<t���?���>">pP?N�F�t�!�X�N>�H�7x�>�s�>���=
�P?�S
���<@      ���=l�ƿG�?����!Ľ�b�D"j>���>@��<vE��5���j,�����>��~�\]u�)t�>��e=om��8��?$�"������(�DE������w���}<?�P>g敾�/?�bq=N�����������9ƾ��ʽ3t?�Q{=m��l���m=�J=T $<��!��W�<ՐY<�Ub='��<�ó�=	����=�0�<ڟ��ʻ=�R,=+�'�&���鷽N��˾���L ��5�e�½�,<�d�=��>h����(o=���r�;8������:�� ��[=���_F�c8����>ʭ��[�X �=)'-��/�Z�<����ꅐ���y����>����I��6��T=����=�*m�Y2���n����<d���)�8>p�}>Vr���-�9ZҚ>��u�4P:����=u=]q��BP��{�����#��>Ll�9B'?����n7���>����֓>9�
<�����=��"R�<h�=p?/=�e,���~��=ܲj��tz=&�d=߂>m%K����V���ȽG�.��]�����3-�Af>z��/B>���%��<
�Y=�Խ�7<���l�<� ��|�=��;�=�=�꽁�<�eE��<5�5���r��6F=�]%=�м��{&>JE��}-���0>���=M�;�@���<2�'>����]]�=u�
<O0��f�7>d ��J|�@���G�0>2�����9��Y����->�M���A�hX�<uI�/ [>��=;�9?�l)��Rؿ�^�=Ӕ]>3;6<�M޾�Y��e�E?UhT���<j��ˏ�;�ﾎ��>�>�~���𧾼��>�č;����侟o?>Xy��VZ�?��,�����9<���=T��>P(Q�7�Q;��?��Z=���%��>���}94���!����0ϻ>���{���03!����>C/>� �����=�ƽ���:�)<�y�<d+��������j����٠����=��p*=�'��I½ 1ӻf�=�o�= �j<�=��g�Z�[�~�=��*���=��,�ؽ7���@�s<���=�4�=~�E��Z�q���.�=�ry=�½T�N�FN���s��$#��Y��cU�>�*o>�,�<H3ݾ5�6�暭=���7[�>\&�=�罶q�=vz?Lp¾����R�>��m�i�=bH���ڡ>(��<��=��<��o����i���"��H���=g���h�����>pA�>2������=���>�া�j�!����'�������fؼ���Pi����:��=[���+�P��<O�Ͻ
R���>=U`��:��!��<���<b���>��o=���������=vs��xażu�i��w'��L�=.׋=ŗ��F<�ɽߦ>B|�=bI��&��=�� >fs>F�>���?9��xa羀l�>�Z����M?��3=� ��6����|�6�=����B�N?4��=�_�=`O�>|Dj�������)��=D�8���׼�ꃼ(?�2�{��܃X>���,��>�瘾����+�=>>��Z.�A��l��| �cd�~�>�T�>��=�-�{�>	(���x&�A�>BW��/����6�> \`��l>:a>4	�� ��>���>ر�=y9[=�X��P���~M>>��U>�˾�ag?�'�=�S	�&�d?���:��>ZD�= ��>��X>���6?���?r��E<�%?�^>⑳���>��D�~c>/����?$�j����#���6x�
��� �:L��dG>4��pj>�?��J�?0>E>/~�>Vϯ�]���5Nk=�mþ��c�v�źw>�W�48=Sp�>�#�>Q��r�>J��O�?>�>Md���k>ų�?��@>zh�����ʡ:�3_�>F#2?���pL[��z�>��9����t���@4S;ܘ����s?�E?Bح��r�<�����e�" ���>C�e�ǃ@>�k�>��W��~�>�����߁��X=6$%?�(���$~�b�(�վ��aMe?�
T5?j��=�U>%�y> �K�����$��#�>�2�>8{>@�t���=N&�U`����'�Eݗ�+�'��u�>}>�����^?!�;�f"� ����<�溾���=�!m>�Y�<dF��?���*ĺ���>k!]��=|�Ӥ�������?���Sg]>����_�p>�9�=�L����>4��A�����Mu=�1��(i=*�����>=����������>�C%>{K���ĺ>�A#��n��t`�!�> ��%=��0+��z!�=Ib��q^b<� 6>����[�� �=�پǶs>$(���I'=�!i?DA�X^�Ԯy=.�?�V>�.0���"��o���=��z>�	� �Q4>��Q��y��Is�4�Z�Y����?�֐>G���P�E�����=m!��	�{�h�A=�w=�$>�G5��!D���-��������y>5X��M������>)���H?IN����=z��,+�Έ�����X�u="�3=�����ɾ��s��^>�߼1e�>H��=|�;�'7	>�y�=$>�G"�� �X>iح���<1���ia>�/�8�%���'����~�jr�����<�1���E��]m�\UE>('�>)�>SSG�)��Q �>;Ӈ�'z�=�?�>0�=��9>Q�s>ds�>nc��>0J�V�=�۽L�1���O����>u柽\�ھ8�+>��{��*~=�ɐ?�o�����5��>��,��>ԯ���t�=5,����>�v"�j�z=�K<)H>4mM�hK�-x��=�)>�D7?y�'?\D=o��1&�����1��<����nd�=����*OF����=L�w=;�����5���=�5��>�=`��=����m�<}z=�� ��#3	��L�=���Z7ۼ\�,�s"���吼���=�f+��w��x5�oV>��o��<�/���9���<��ܻ���=���?�*?��n>��I��Ͼ=�ξv�X>��>=Ax>��Q���=9t���W�ZX��*>2�m�0�?��>}�����>���}V���j���y> #8�!�=(�a>��H�@a��z�u���"��<=��`�>X���j���0����W����?�S�����>�bD��ܽ���+?��.�+�-<>u�����>"ϧ=�ɪ�qz����ȿ��$?�	�=\�ٿa=] ��T���5�?|���u1��f��s������H��c����	?�⚾-�����>r#�=�HG��=��e��h g>�����H�s� ?�k@�����	϶�8<�>�����>��<�*>󸅿Gh޾8]D=5?&��a�Þ�=�4� Z��;(��P���K#@�>��U�9�Y�c>/�>����">�=?�2>�Gx�p���\�x���<R̀��d���8��/��>*wL��Q�>�H�u�\�J�v>�W׾�g�>�\^=ಯ�G���\Ž�0k=kv��G+�6���S�=\����+<�G�\�=УI�[Z콁*�=�H����;^w�=(2�<zF�=��v�Lf+=���><@!�;�1��@.��?�&!O=��=�r�;�S	�=z�q����R� �e�A� o�=?�����z��6���6���O���[����=?�׽�X�!W*���V��;���9O=@N�=�� =iW�o�<��<;b�~4���1=s�4�s`� Z�<�؋< ����T1>���a�8=I����Y�<7���')<��$�=�訽�q�;�/\��_z�ʌ<��4����<��-�����y�!���<}� >��=��o=��>�76=O�нT�n�Y���.��
��'��=�F>�m���k$�j���z>j��<��C= Ӄ�Rg�9[�=�����&������������b���=C���c^�`���a1�4��=�=ߚ��%?�1�=2�Q=�m������<
�=�<S�<2��l�K�K=a9]�]�`<�|�=GƲ<憲�H�=���iŚ<��'��f�������=�R�=�	��3��؉8��s�/�缞)"����=]�޻Hbn�Iֺ�'Y=w,�<yܾ԰ľG~o?a�߾�Z�]d����H�>�u=�~�����b���]@?������ �ҙ��G;�3I?�>~4 �{ھ^�ѾC�6<�L��9��Z�h?{�Ž�VD�f9F?�ǯ<tJ���=�E�>�>�4�U������>���V���:�>b�2>BZ�>��M=&8����\>Ly��?�= ͽu��=����˛�m>#`ӽɏ-?�<Y���/>Jid>;$�<�j �M�>T� �[����9=�H��eɈ>s����Iv=O.>ˢ�>���A>9���F��?b��������r(����=ub���.�>���>�r�7ݕ��ܵ��HR=g�G���+>���=��˾���_�p>��ʽ�,���F�>d���Ŗ��@��=Jk�>dĽ����=�&��M@=^Ŀ�2ýFG��F����<��/�B��=l�o>�w=�֨�R��?~��>p�
����5��Y0X��u�>@7;3h����a>������Q��޼�����H� �ҽ�����>����"�F����=pJ=R��>�V3=T	b=�e���Կ?Y>�`ؾ���>襅�M5���ie>��R=��>7�`>+�{�>�]Y�畿���\>�+W��a=�.��<�<�L��w�ۼ�N�=<(���F=�==!�N��=f�M��(�&��M�=�!�<�ڎ=��=�Ng���=#�=������=?u��j�M"]��Ľ�'�:��[�h�������#������=�#M=�n^<g�긼)�ؽ����p=w��>��P��>�>w}2>oU=��;��<�#?A�>W}��׿��=���&A=�������>η��ˣ=��ǿ�����:v�,�k>-5=J�﾿�I�J�#=�B>\��� �3?�0Q> r�<�x�.����Z��$���\1>�cf>��;��J=�����d_=�U�� W<l��=�mY=`�¼&}�=87�<��'�J��=k�=$q��(�����k��>�K�J$���_�=�<8���
�J� �_�P�_=R_�=� �Bh�=S��(㭼ޮ�@7;�:�� ? �����ZJ=Y9������񽔪��l*�=}�ſ�1n>C6ɿ2�O=��8�v>+�=���x����l�>c�>��>ȏ��/�>����&q�8��> �	�<Ŀ{�6=���=s��/ē>�䧾,t!>h~�>�
��~xx��'��`E��3�'��>��d<�fL�ߟ��E����?r9?��>�>��B>�$�>��>��>�;%?��<��d�h�&� ��<�VZ>�[��9q�SbJ�C�=Шa��
>��>�����?��?�檊�&t�>�>}?��-=���>��>bc�>�	?l��> b�<`�m>��ξ�I� 8����>p}��C� �>�6E>�t����N�`s�="@�=l��f=n�你�̻Av�=Ϸ$��W���R=Gh�e��=_'z���N=Rc=�	�=����=�T��9����r&����=g��x�7���=�	=��O>,��=��>I�u�gy.�	��=&�$=Қ�<r��vL���D>��>�����P>e�>4͓>�H�>�ټ��Q���=w&��v�L������$��,?�SW>=z�=d��>��0�e�����>��`>���>
G�>k�=n�>u.�>��=��>@@`=��>�R׾��㾄9׾�=hFG�����==>!�+>	�$=#f��e5�\=�=X�U>U=F듽4vݾ�*Z<E,&���?;Ȃ>�v�����<��>_/��s�=�h\>�����A��*�=��>�.>J�`>&�j<Ai�=�+*��mʽ�����x���j=�>�>h-��y�~>�����3�t��>�Je=�>I��=Z�#@�=�0? |����*3�͔��t��=h ӽ__c�NiR�ys���Z)?�R�r�ƾy���~��ꏉ���C?Ň�=�m>m憿��1;)���W�=!��|o?����Ŀ��?R��=d �ӌ�>sF4��1�>0�4�����Z>�_п�C�>
���>s����F`g>'l>ۂ���;ʾ	O���9=O��<eQ?]�>M���X���> _��W�/�r8�>��I>	�=^�
��s�>v��рS>�����z�C�4��"K�8���$8���=��!�J�=_�>�Y7=RCM��ʲ��-�>9T"�c�<