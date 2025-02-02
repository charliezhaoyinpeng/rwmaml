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
qBX   2841834737376qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2841834736512qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2841834741216qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2841834737184q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2841834738624q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2841834739392q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2841834736512qX   2841834737184qX   2841834737376qX   2841834738624qX   2841834739392qX   2841834741216qe.(       P剽��;?��>c4�2F#>�f�������>�?]i{�W`?��ܽC�}���9�?�y�����>����h��@�=��'���=��np���{?�Fa�:� ��o�>� ]?j0���>��v�����.쾥5���>9��=EAb?�Wx?܎t?�y�(       ��=����U�=��=Ŭʽ~@6=T=��=�+��=�d<��q=/D>��Խ��������>�b+<"W�;�$�w�=�����{0��U��棽<-!>�1���>�˽E-�����={��=n@��K�~=�����'�=wD�=�f�=��W�(       
�u?����A������d?
>���>e�?�z��>��x�V�	�N �|S>;h��H-?C����TҾ/!�I����p�r�A?�x�>��?�I���z��kZ��*��Q�I�yyN���'?���v�
a˾��?h8����
�֒�>���>�:a?(       {�����M�情�6���t�.:�G��=��<��=���<G,k��ߍ=�d<^
�Q[���< =2ĩ��#>�+>e��=�������m򽗩+>��=�D�=Z��= �=����O$=�>�>J���Q��d�=���==�(>�ý�&:       (+�=@      3��=-�=s3�9K=�38����<��"=�&�)��B��=���=bՙ�ޮ���D�^^?��5ϽU� ��p[<���;���<�E=8�P�=� :��M�N�0=Q�=Ƞ���H���5�R=M��'6�:����X�ɽ��=�^ܼμ���<���=|�3=�PI=C�=qg�=_L�=�7�=/Z=��B�U*n=\�=��=�t�	m���=�٢<����_�̯�=�������\����=�n���s �ꛚ��S��q-���'ٽ�$��U$�=�%>��ϽM�5�����.\<NJ��/�=�����!���=��=�m���=�,��Q<��7=n�<ш5���q�4;c�>�c�=��]=)�=���	�=�l���1�=�re=��Þ�*������=�=80?=��H�i+O;�����O룽r�=ٻ����\{6�Ԫ���ۦ=7D�̭��>V@�B�XQ�F:Ľu��x�=��-�ZA�=jYX������}�&>��=�6Ҽ�f����=�������$~����=g+	����=.{��p��<F	�=<�v���½=����A>дb��l=(�d=��>-�ǽJ�b=�=���=��;�щ�a����e����=68�=���=��="˽�>��[��Q=gg�<$�)>�<�� �=C��.>��7>��<���=�6�=`i<@a��&n���R�J&�E2N=��=��(��=F�`��g��|���&i=�o���m��s�����o%�ÇF��Au=���=���:������M�=�K��h�
>��=�P�0�ü�]~���r��X��V�߻���'==(��<��N�#�>�d,=/����O�f¹=���CEv���=@s~��: =h�=&Cc����u@>��&�N-��[=� >&#�}*�=EK�;_n�=6Ώ��=3�����<�C�=�]ǽ�D���)�uΦ�[<t?㽴����=�����|%��_H�)�=v*�֒>���7%>�ꃼ4�%�H�`�$�)>-P�=a�<����{a�=:��=e"�=�qV�5HP��O�d>�&�=���<���=#@�=v��=2۽ᵾ�S�>�J�=sc9��Gh�Sq
���I�����5�LQ=��z�=�^F�;��Ӗ=��ֹ��I�-L�=��=�?= �?��_�`ż���=-�4�I86��M=���<����w��|}=i#�<�{\=�&���O=�C0��zĽ�:�����<5y���>��`��;;��=�\����=٘��S1>-�����=t7����ص�<K��<�缋P�=�&��*W�=,�?<�߽��=r3=h�$=�`�;V��=���t����佦�o�yE�=9�<a˽pz*���:����=>%��;�->�V=�5����.A�=� ����#=B	����=��q<&�ٰ	>�e�X��<�F�=����hFƽ ��;J̈́=��=Ɔ1>v�� m��s�;K��GR=/7��^��#6�9��=��=v0X��>j�=�K:�R��=u;!��;��x�=2#�<Ds�A	_=���=���<a���<p9�<y�=���n�=��{<N��Ҩ�������a� ��<8����ҽ��ٽ��$����=d%��%�!�
��m1��0�����x�C=ͨ[���Q��4�=�c >�T
�u3(�9Ϻ<*����Rq�c�G���=�=���=�-�=B�<����4�<p� �{�c�sЇ�tEǽ����:ZA���UP���������t�f=5疽��f���U=b��=O{�=�����=�ǽ��=������=��<`��e6�������&�.6����	=Pl�=���<bU>��=�� ��:�=�7�d�e=���o=��G=���ϓ�Kab�8;����7�g�<��=���Mϻ�ٌ���ڽnc�=���y��m� �{���.�B��= ��;z��ѐ ��'�����RνTq�������x���b<���d��t��\b��K��jp6<;{�=��=��9��� >�#��ύ�`�m=Y��8��(��M=�%���=,��`� >Qn2=%m׽P
�<�g*��������%�����=�	�Z9q��	��#iȽnׇ=�+'�0�r=M)��g��)�=T�=U�$��x����=%�=���R���=�Z~=s��=w��>�=a��=g+[���8��vJ=�v�z =�����=Ҿ6�Q4����)�K�=
�=1ͽ��>������������(�E��=��.��J�=`Q=QK�=�O>yn	��O=s��=\�=|{����X=����O�=�t	>��>�x=' ���Ƚ��Ǽ�=Ի���� ��3�<�P�is��ᘽV>��<B	(��e��D��0]���<�&�;^���n��?=ex)�&��½�X0��~<���.�)>`�=����=,>��:�3�>�d���=ֽ+
">�$�={�����(�~@����:�f�<%>=Z���v����=�N��)W=�������=�����=�6����="��=��;�n>���=:q>�t�<q��ŷ=�׵��`�=���`܁;�b�= ��;�B��{��ڃ">a�O�Ư�=�?���̽h��x���4pM��)���=PR�l~�=�Ć=�_6=�Ž�k�^�=j�Ѽ��=e��=*��h6�h&��[��=J���b��@=�Z�H_2=Pe(�
��i�XYV��ΐ�B#v�T՞=��0��v���uɼ�����c=��� K���R=���,�=:��=$�a�C���Ƚ��>^� ��qF���7;��Ľ8�����<�UA>�>E=x3��"�G>vc��<��=H�l=��(>f"@>eA>h��ԇ��䃽r���Ԫ��=�[��罦�=p陽��5>4ׯ��2�=tt4=q5�=Lj=������<{���>m��w��=N)l���=����41=��=&��<3U���<ɽ)>�X�xO��O%�
��^�&c>�������������=��=ɡ����">�t���s�=?>��=V?�7v%���'=D=�=h�'�������;rs�=��0>��A�m���蕽�c�=�F���Nƽ�A�����=,��G@>�=p�1�� �=�&�'65��h���h!>���A��x�-��y�=���=o��AM�=�G=n����<�b��ߌ¼uv���٫=L�=�==^��<t��=Ҽ�����<u�=��>�Bn=�4���a��X��<<Ƚ��=*ɽ�彀�h=z&����!�V�=u$���Fu�m���K��Γٽ#�����콀,a�4cN=��ɽ�y�8�a=C岽$#1=�wG��F= !麺�J��3���y�=�@�=�.�<A
>e�>?�L��=�>�4��M�<�k�08o<�j�~�M=�w7=A�$��2�<��<��=Mx��2=�"�<�y����#�[�za�LV�5��Խ�=�>x<w<G=zN�����<��t�wz�=) ��)R�=Wפ;h?�>��=o�����<V!μ<��=�6�qY>#)���>4��<}@�y�:�9pB=�-=��Ͻ��=��S��^�=P��<�0!����<�n��둈=CK�g!>Ӽ�%>EC��v>��ɽ��Q=֫���$��=Bہ<=�KF��y?G�)_	��:=0{�=V�D����]�=��=��ݻ�s��Ŀ=Z��=�ȽG���zϕ�w�"=wM>!�=.��<�����0�=1�/=�^'>��S���	<���=Ka=�V����z<D�,=����x�N�\%��0�0�w�#����=����:�=��˽h�N�;h��؎=J9���>9�X��|�
�L=α�<�ͽFO�"�=�ʒ<��0=;��;���=��=��}��
�<��O=t�x���'=[
��{[ؽV�'����=����a�>%�#<���=J1��8b�F���50�ӆ��� >�~^=�������p����M�=�K=?�<��=�J���-׽S�'��d�=_�+���=��^�0:�=C����O�=EG;}W�=8�>̤3����=lJt=�]ս�+��H�$> r�<�-�=��*��ǽH =�����.���=�����g=����Y�:�=�#���5�o����dQ�2*��	�=e[��,�N�<��=v����/;��нN̶�����%>7F�<���=�7�=��g�p�=�0�=6q�=�z���=@��<��=[�>��`<W��g&�@�<�ߍ��͇�s�=�j�=.�[�
� d_=n ��6����ҍ���ꧼ�S�<�>G>=�&<=��Ͻ�����ۥ�r�Խp��<�Zټ��<=��+���~ȼ����3����=��Q=�/�Md�;`<
=*M=�(½�=��1=$=�<>"(��������=�s���<X�=�t���=����=!��<��>K��ӈ���L����=j4F�S�=;��;iU���T5=w�.�ׯ
=���<s�D�{�C�E
<&�=��C>���m>΀L���E�C���1�C\>�P�=���q��S*��XP�2Gb��A>�V�����=ȑ�=�w�u����f9<���u�=��	>:�T=ez;��ǽ3߼�����G�����?��;P���������l��� �%����=��h=Ǥ=3��=x�S�N;���P#��5��0>�潮�����=᭠=�b�=�L�<=�Լ��=��=�n>:7����>�3"��Q�=j�O�>υ2>��<���<�?S�l%6�M��^�<�Z=���<ѽC-�i�X=��̼���x=��ɽsd>=*��:�C=��=�*��2����=Q������򑽸�����̽��\=1��=�]����+�u꛽K�>���=fN�=p�ҽ�T>���&¼��޽ z;���;�:�=%;>�)�=�ȴ= �>�D�=��9>{@���
�=r�8>��J=�&��6>S�$���t�
�E�>��>�p5������<:�������t5�=KS���=bE��,<��=z��"$��B7�mm�;n����f�U$=�n��=x-���@>�b���Ԅ=@��D�=�V8�0 �A�7�~�	=��ƺ�*J�!�����W=]��^.=����9�=([u����=�E
>�{�=e3��u!>ظ2�(p�=ƺ���n>��ʽvY!>�0��8ݽ��I�����_������a>R��~���;�=��*�l�-���;�[�!>�2>��<z�>s�<J�=��=.u���>����F�0<#�������<��]=6w3��<=����Y�=@^p<�A�=�~0���6��=ު�<��b=�َ������
���E�=՞"=$CV������0$��^�� x���2��}��^<�<����۽�U����W=�I[=�ü�v��މ0�BPǽu��%N=�Υ=u��=ɣ>�M�P��Dƽ`=V=>��>�Ս���=o���x���傉=5ͩ<��M7����i��=�o����)�1*>#Ž.��=u;�=5�)>.��],��c)>���<{(���;:��<���; ��UP>����h�=r�J�a1��n�{=�W9�4��=��k=�c>>*��W�=����.(�3W>`�?=��<=ަ۽x���H���>qL<=g��=���=._����	�;"2��=��!<��<�����R�<�蚽��=���=�����<~<K���a5��^OQ�8�=P݇�H�%��+�=Tn���A��!8>�8�=��������=�����t�7�=��A�b=��#>���=���cЀ=!E���v<�=QƽI�=r�"��`x��w�=L��<�	 >>���E->]o����=�/=TF轍�~<�==��<y�=D�ɼ��=.�9�x>�p�<�/��d_�P��=�=�U>�/=����8q=HҐ�ric;0�T�G�
�a�PP�=C-Ľ,<��\zҽ&��<�Q=��,�ʯ�=��=���=*�Ⱥ=v=����|˱�dM%=���Ĵ=��=*��=�Y ��p�����LM���Ǆ�|�=�I��*�A<e�3��S�=Ǥ�<G>:�'>>l!���=9�=�WŽ*����� �ռ�L��'D���$v�nSٽb(_�m7�\!���o�ɏ=�߽P&�=�{c=����Em
��f=�jD�о�=�y%=�?۽���=� ���i�<x��bZ=
߉=��=U��]�=k)� r�9Vw�h�`�